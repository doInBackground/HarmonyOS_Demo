import { ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { LogUtil } from '@pura/harmony-utils';
import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;
let tcp: socket.TCPSocket = socket.constructTCPSocketInstance();

/**
 * Defines the event handler to be called when the worker thread receives a message sent by the host thread.
 * The event handler is executed in the worker thread.
 *
 * @param e message data
 */
workerPort.onmessage = (e: MessageEvents) => {
  // let data: number = e.data; // data：宿主线程发送的信息
  // const view = new Int8Array(data).fill(3); // 往收到的buffer里写入数据
  // workerPort.postMessage(view); // worker线程向宿主线程发送信息
  LogUtil.debug(`worker-socket测试:worker线程中收到消息.${e.data}`)
  switch (e.data) {
    case "START_SOCKET":
      startSocket();
      break
    case "STOP_SOCKET":
      stopSocket();
      break
  }
}

/**
 * Defines the event handler to be called when the worker receives a message that cannot be deserialized.
 * The event handler is executed in the worker thread.
 *
 * @param e message data
 */
workerPort.onmessageerror = (e: MessageEvents) => {
}

/**
 * Defines the event handler to be called when an exception occurs during worker execution.
 * The event handler is executed in the worker thread.
 *
 * @param e error message
 */
workerPort.onerror = (e: ErrorEvent) => {
}

//启动Socket.
function startSocket() {
  LogUtil.debug(`worker-socket测试:准备启动Socket`)
  // let tcp: socket.TCPSocket = socket.constructTCPSocketInstance();
  tcp.connect(
    {
      address: {
        address: '192.168.1.254',
        port: 3333
      },
      timeout: 5000
    },
    (err: BusinessError) => {
      if (err) {
        console.log('connect fail');
        LogUtil.debug(`worker-socket测试: connect fail`);
        return;
      }
      console.log('connect success');
      LogUtil.debug(`worker-socket测试: connect success`);
    });
  tcp.on('message', (value: socket.SocketMessageInfo) => {
    let messageView = '';
    for (let i: number = 0; i < value.message.byteLength; i++) {
      let uint8Array = new Uint8Array(value.message);
      let messages = uint8Array[i];
      let message = String.fromCharCode(messages);
      messageView += message;
    }
    // console.log('on message message: ' + JSON.stringify(messageView));
    console.log('remoteInfo: ' + JSON.stringify(value.remoteInfo));
    LogUtil.debug(`worker-socket测试: ${messageView}`);
    workerPort.postMessage(messageView); // worker线程向宿主线程发送信息
  });
}

//停止Socket.
function stopSocket() {
  LogUtil.debug(`worker-socket测试:准备关闭Socket`)
  tcp.off('message')
  tcp.close()
}
